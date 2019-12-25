<?php

namespace OAndreyev\Mink\Tests\Driver\Custom;

use Behat\Mink\Tests\Driver\TestCase;
use Facebook\WebDriver\Remote\DesiredCapabilities;
use OAndreyev\Mink\Driver\WebDriver;

class DesiredCapabilitiesTest extends TestCase
{
    public function testGetDesiredCapabilities()
    {
        $caps = array(
            'browserName'       => 'firefox',
            'version'           => '30',
            'platform'          => 'ANY',
            'browserVersion'    => '30',
            'browser'           => 'firefox',
            'name'              => 'Selenium2 Mink Driver Test',
            'deviceOrientation' => 'portrait',
            'deviceType'        => 'tablet',
            'selenium-version'  => '2.45.0'
        );

        $driver = new WebDriver('firefox', $caps);
        $this->assertNotEmpty($driver->getDesiredCapabilities(), 'desiredCapabilities empty');
        $this->assertInstanceOf(DesiredCapabilities::class, $driver->getDesiredCapabilities());
        $this->assertArraySubset($caps, $driver->getDesiredCapabilities()->toArray());
    }

    /**
     * @expectedException           \Behat\Mink\Exception\DriverException
     * @expectedExceptionMessage    Unable to set desiredCapabilities, the session has already started
     */
    public function testSetDesiredCapabilities()
    {
        $caps = array(
            'browserName'       => 'firefox',
            'version'           => '30',
            'platform'          => 'ANY',
            'browserVersion'    => '30',
            'browser'           => 'firefox',
            'name'              => 'Selenium2 Mink Driver Test',
            'deviceOrientation' => 'portrait',
            'deviceType'        => 'tablet',
            'selenium-version'  => '2.45.0'
        );
        $session = $this->getSession();
        $session->start();

        /** @var WebDriver $driver */
        $driver = $session->getDriver();
        $driver->setDesiredCapabilities($caps);
    }
}